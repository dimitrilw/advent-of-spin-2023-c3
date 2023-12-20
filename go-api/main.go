package main

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	spinhttp "github.com/fermyon/spin/sdk/go/v2/http"
	"github.com/fermyon/spin/sdk/go/v2/llm"
)

//go:embed styles.json
var StyleOptionsJson string

type StyleOptions struct {
	Styles []string `json:"styles"`
}
func NewStyleOptions() (StyleOptions, error) {
	var s StyleOptions
	err := json.Unmarshal([]byte(StyleOptionsJson), &s)
	if err != nil {
		return StyleOptions{}, err
	}
	return s, nil
}
func (s StyleOptions) random() string {
	rand.Seed(time.Now().Unix())
	return s.Styles[rand.Intn(len(s.Styles))]
}

type Data struct {
	Place      string   `json:"place"`
	Characters []string `json:"characters"`
	Objects    []string `json:"objects"`
	Style      string   `json:"style,omitempty"`
}
func NewDataFromJsonRequest(r *http.Request) (Data, error) {
	var d Data
	err := json.NewDecoder(r.Body).Decode(&d)
	if err != nil {
		return Data{}, err
	}
	if d.Style == "" {
		s, err := NewStyleOptions()
		if err != nil {
			return Data{}, err
		}
		d.Style = s.random()
	}
	return d, nil
}
func (d Data) toPrompt() string {
	return fmt.Sprintf(
		`please generate a winter holiday story that:
			references the Go programming language and/or Gophers;
			and takes place at %s;
			and contains these characters: a bunny, %s;
			and references these objects: %s;
			and is written in the style of %s;
			and is limited to 500 words
		`,
		d.Place,
		strings.Join(d.Characters, ", "),
		strings.Join(d.Objects, ", "),
		d.Style,
	)
}

type Payload struct {
	Story       string `json:"story"`
	Style       string `json:"style"`
	Nanoseconds int64  `json:"ns"`
}

func generateStoryFromPrompt(prompt string) (string, error) {
	inference, err := llm.Infer(
		"llama2-chat",
		prompt,
		&llm.InferencingParams{
			MaxTokens: 500, // 100,
			Temperature: 0.9, // 0.8,
			TopP: 1.0, // 0.9,
			// defaults
			RepeatPenalty: 1.1,
			RepeatPenaltyLastNTokenCount: 64,
			TopK: 40,
		},
	)
	if err != nil {
		return "ERROR: Inference failed.", err
	}
	return inference.Text, nil
}

func init() {
	spinhttp.Handle(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now().UnixNano()

		d, err := NewDataFromJsonRequest(r)
		if err != nil {
			fmt.Println("Go API, error:", err)
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		fmt.Println("Go API, data:", d)

		w.WriteHeader(http.StatusOK)
		w.Header().Set("Content-Type", "application/json")

		story, err := generateStoryFromPrompt(d.toPrompt())
		if err != nil {
			fmt.Println("Go API, error:", err)
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		p := Payload{
			Story:       story,
			Style: 	     d.Style,
			Nanoseconds: time.Now().UnixNano() - start,
		}

		fmt.Println("Go API, payload:", p)

		json.NewEncoder(w).Encode(p)
	})
}

func main() {}