package vectoria_metrics_api

import (
	"encoding/json"
	"io"
	"net/http"
	"os"
	"strconv"
	"testing"
)

// stdRangeQueryResponse mirrors ReadonlyRangeQueryResponse for encoding/json comparison.
type stdRangeQueryResponse struct {
	Status    string            `json:"status"`
	Data      stdTimeSeriesData `json:"data"`
	Stats     stdStats          `json:"stats"`
	IsPartial bool              `json:"isPartial"`
}

type stdTimeSeriesData struct {
	ResultType string          `json:"resultType"`
	Result     []stdMetricData `json:"result"`
}

type stdMetricData struct {
	Metric map[string]string `json:"metric"`
	Values []stdValuePair    `json:"values"`
}

// stdValuePair represents the VictoriaMetrics [timestamp, "value_string"] format as two float64s.
type stdValuePair [2]float64

func (vp *stdValuePair) UnmarshalJSON(data []byte) error {
	var raw [2]json.RawMessage
	if err := json.Unmarshal(data, &raw); err != nil {
		return err
	}
	if err := json.Unmarshal(raw[0], &vp[0]); err != nil {
		return err
	}
	var s string
	if err := json.Unmarshal(raw[1], &s); err != nil {
		return err
	}
	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return err
	}
	vp[1] = f
	return nil
}

// stdInt64 unmarshals from both JSON number and JSON string (VictoriaMetrics encodes
// seriesFetched as a quoted string when the value is large).
type stdInt64 int64

func (v *stdInt64) UnmarshalJSON(data []byte) error {
	s := string(data)
	if len(s) > 1 && s[0] == '"' {
		s = s[1 : len(s)-1]
	}
	n, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return err
	}
	*v = stdInt64(n)
	return nil
}

type stdStats struct {
	SeriesFetched     stdInt64 `json:"seriesFetched"`
	ExecutionTimeMsec stdInt64 `json:"executionTimeMsec"`
}

// TestQueryRange fetches a query_range response from VictoriaMetrics and verifies that
// ReadonlyRangeQueryResponse.FromJSON() produces the same result as encoding/json.
func TestQueryRange(t *testing.T) {
	const rawURL = "http://127.0.0.1:8481/select/0/prometheus/api/v1/query_range" +
		"?query=vm_http_request_errors_total&step=1m" +
		"&start=2026-06-04T07:59:00.000Z&end=2026-06-04T08:09:00.000Z"

	resp, err := http.Get(rawURL) //nolint:noctx
	if err != nil {
		t.Fatalf("http.Get: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("read body: %v", err)
	}
	t.Logf("response: %d bytes", len(body))

	// --- parse with ReadonlyRangeQueryResponse.FromJSON ---
	// NOTE: VictoriaMetrics encodes each value pair as [timestamp_number, "value_string"].
	// ReadonlySeries.fromJSONArray calls Float64() on every element, but the value is a
	// JSON string (e.g. "0"), which causes a typeRawString(7) error in BaoHuLu fastjson.
	// This test will fail until the generator emits Type(parser) + StringBytes() +
	// strconv.ParseFloat for string-typed elements in @AsArray repeated-double fields.
	var fast ReadonlyRangeQueryResponse
	if err := fast.FromJSON(body, nil); err != nil {
		t.Fatalf("FromJSON: %v", err)
	}

	// --- parse with encoding/json ---
	var std stdRangeQueryResponse
	if err := json.Unmarshal(body, &std); err != nil {
		t.Fatalf("json.Unmarshal: %v", err)
	}

	// ── top-level fields ──────────────────────────────────────────────────────
	if fast.Status != std.Status {
		t.Errorf("Status: fast=%q std=%q", fast.Status, std.Status)
	}
	if fast.IsPartial != std.IsPartial {
		t.Errorf("IsPartial: fast=%v std=%v", fast.IsPartial, std.IsPartial)
	}

	// ── stats ─────────────────────────────────────────────────────────────────
	if fast.Stats.SeriesFetched != int64(std.Stats.SeriesFetched) {
		t.Errorf("Stats.SeriesFetched: fast=%d std=%d", fast.Stats.SeriesFetched, std.Stats.SeriesFetched)
	}
	if fast.Stats.ExecutionTimeMsec != int64(std.Stats.ExecutionTimeMsec) {
		t.Errorf("Stats.ExecutionTimeMsec: fast=%d std=%d", fast.Stats.ExecutionTimeMsec, std.Stats.ExecutionTimeMsec)
	}

	// ── data ──────────────────────────────────────────────────────────────────
	if fast.Data.ResultType != std.Data.ResultType {
		t.Errorf("Data.ResultType: fast=%q std=%q", fast.Data.ResultType, std.Data.ResultType)
	}
	if len(fast.Data.Result) != len(std.Data.Result) {
		t.Fatalf("Data.Result length: fast=%d std=%d", len(fast.Data.Result), len(std.Data.Result))
	}

	for i := range fast.Data.Result {
		fm := fast.Data.Result[i]
		sm := std.Data.Result[i]

		// metric labels
		if len(fm.Metric) != len(sm.Metric) {
			t.Errorf("result[%d] Metric length: fast=%d std=%d", i, len(fm.Metric), len(sm.Metric))
		}
		for k, fv := range fm.Metric {
			sv, ok := sm.Metric[k]
			if !ok {
				t.Errorf("result[%d] Metric key %q missing in std", i, k)
				continue
			}
			if fv != sv {
				t.Errorf("result[%d] Metric[%q]: fast=%q std=%q", i, k, fv, sv)
			}
		}

		// time-series values
		if len(fm.Values) != len(sm.Values) {
			t.Fatalf("result[%d] Values length: fast=%d std=%d", i, len(fm.Values), len(sm.Values))
		}
		for j := range fm.Values {
			fs := fm.Values[j]
			sp := sm.Values[j]
			if len(fs.Values) != 2 {
				t.Errorf("result[%d] values[%d] Series.Values len=%d, expected 2", i, j, len(fs.Values))
				continue
			}
			if fs.Values[0] != sp[0] {
				t.Errorf("result[%d] values[%d] timestamp: fast=%v std=%v", i, j, fs.Values[0], sp[0])
			}
			if fs.Values[1] != sp[1] {
				t.Errorf("result[%d] values[%d] value: fast=%v std=%v", i, j, fs.Values[1], sp[1])
			}
		}
	}

	t.Logf("OK: status=%q resultType=%q series=%d", fast.Status, fast.Data.ResultType, len(fast.Data.Result))
}

/*
go test -test.fullpath=true -timeout 30s -run ^TestQueryRangeFromJsonFile$ github.com/ahfuzhang/MetricsExplorer/server/generated/vectoria_metrics_api
*/
func TestQueryRangeFromJsonFile(t *testing.T) {
	body, err := os.ReadFile("1.json")
	if err != nil {
		t.Fatalf("read 1.json: %v", err)
	}

	var fast ReadonlyRangeQueryResponse
	if err := fast.FromJSON(body, nil); err != nil {
		t.Fatalf("FromJSON: %v", err)
	}

	var std stdRangeQueryResponse
	if err := json.Unmarshal(body, &std); err != nil {
		t.Fatalf("json.Unmarshal: %v", err)
	}

	if fast.Status != std.Status {
		t.Errorf("Status: fast=%q std=%q", fast.Status, std.Status)
	}
	if fast.IsPartial != std.IsPartial {
		t.Errorf("IsPartial: fast=%v std=%v", fast.IsPartial, std.IsPartial)
	}
	if fast.Stats.SeriesFetched != int64(std.Stats.SeriesFetched) {
		t.Errorf("Stats.SeriesFetched: fast=%d std=%d", fast.Stats.SeriesFetched, std.Stats.SeriesFetched)
	}
	if fast.Stats.ExecutionTimeMsec != int64(std.Stats.ExecutionTimeMsec) {
		t.Errorf("Stats.ExecutionTimeMsec: fast=%d std=%d", fast.Stats.ExecutionTimeMsec, std.Stats.ExecutionTimeMsec)
	}
	if fast.Data.ResultType != std.Data.ResultType {
		t.Errorf("Data.ResultType: fast=%q std=%q", fast.Data.ResultType, std.Data.ResultType)
	}
	if len(fast.Data.Result) != len(std.Data.Result) {
		t.Fatalf("Data.Result length: fast=%d std=%d", len(fast.Data.Result), len(std.Data.Result))
	}
	for i := range fast.Data.Result {
		fm := fast.Data.Result[i]
		sm := std.Data.Result[i]
		if len(fm.Metric) != len(sm.Metric) {
			t.Errorf("result[%d] Metric length: fast=%d std=%d", i, len(fm.Metric), len(sm.Metric))
		}
		for k, fv := range fm.Metric {
			sv, ok := sm.Metric[k]
			if !ok {
				t.Errorf("result[%d] Metric key %q missing in std", i, k)
				continue
			}
			if fv != sv {
				t.Errorf("result[%d] Metric[%q]: fast=%q std=%q", i, k, fv, sv)
			}
		}
		if len(fm.Values) != len(sm.Values) {
			t.Fatalf("result[%d] Values length: fast=%d std=%d", i, len(fm.Values), len(sm.Values))
		}
		for j := range fm.Values {
			fs := fm.Values[j]
			sp := sm.Values[j]
			if len(fs.Values) != 2 {
				t.Errorf("result[%d] values[%d] Series.Values len=%d, expected 2", i, j, len(fs.Values))
				continue
			}
			if fs.Values[0] != sp[0] {
				t.Errorf("result[%d] values[%d] timestamp: fast=%v std=%v", i, j, fs.Values[0], sp[0])
			}
			if fs.Values[1] != sp[1] {
				t.Errorf("result[%d] values[%d] value: fast=%v std=%v", i, j, fs.Values[1], sp[1])
			}
		}
	}
	t.Logf("OK: status=%q resultType=%q series=%d", fast.Status, fast.Data.ResultType, len(fast.Data.Result))
}
