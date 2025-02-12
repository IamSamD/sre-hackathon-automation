package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	logger.Info("Starting server..")

	
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		logger.Info("Ping endpoint called!")
		c.JSON(http.StatusOK, gin.H{
			"message": "Pong",
		})
	})

	r.GET("/env-var", func(c *gin.Context) {
		logger.Info("Env-Var endpoint called!")

		val := os.Getenv("APP_ENV_VAR")
		
		c.JSON(http.StatusOK, gin.H{
			"message": val,
		})
	})

	r.GET("/trigger-alert", func(c *gin.Context) {
		logger.Error("ALERT TRIGGERED!")

		c.JSON(http.StatusOK, gin.H{
			"message": "An error log has been sent to trigger an alert",
		})
	})

	r.GET("/_status/healthz", func(c *gin.Context) {
		logger.Info("Healthcheck endpoint called")
		c.JSON(http.StatusOK, gin.H{
			"message": "healthy",
		})
	})

	if err := r.Run(fmt.Sprintf(":%s", port)); err != nil {
		logger.Error("Failed to start server")
	}
}
