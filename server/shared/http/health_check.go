package shared_http

import (
	"net/http"
	"time"
	"wavelength/shared/logging"

	"go.uber.org/zap"
)

// HTTP health check server for Render
// Otherwise Render will kill any gRPC service if no HTTP binding is found.
func BootstrapHealthCheckServer(addr string) {
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	server := &http.Server{
		Addr:         addr,
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 5 * time.Second,
	}

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		logging.Logger.Fatal("HTTP health server failed.", zap.Error(err))
	}
}
