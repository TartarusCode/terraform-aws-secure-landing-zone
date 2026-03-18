package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMacieModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/macie",
		Vars: map[string]interface{}{
			"enable_macie":                       true,
			"macie_finding_publishing_frequency": "FIFTEEN_MINUTES",
			"enable_s3_classification":           false,
			"s3_buckets_to_scan":                 []string{},
			"excluded_file_extensions":           []string{"jpg", "png", "gif"},
			"custom_data_identifiers":            map[string]interface{}{},
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "macie-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	macieEnabled := terraform.Output(t, terraformOptions, "macie_enabled")
	classificationJobEnabled := terraform.Output(t, terraformOptions, "classification_job_enabled")

	assert.Equal(t, "true", macieEnabled, "Macie should be enabled")
	assert.Equal(t, "false", classificationJobEnabled, "Classification job should be disabled with no buckets")
}
