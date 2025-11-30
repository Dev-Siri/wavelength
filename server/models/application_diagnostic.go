package models

type ApplicationDiagnostic struct {
	Error    string `json:"error"`
	Source   string `json:"source"`
	Platform string `json:"platform"`
}
