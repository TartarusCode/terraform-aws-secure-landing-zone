package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGuardDutyModule(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	namePrefix := "test-gd-" + uniqueID
	findingsBucketName := "test-guardduty-findings-" + uniqueID

	// Deploy KMS module first to get the encryption key ARN
	kmsOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/kms",
		Vars: map[string]interface{}{
			"name_prefix":              namePrefix,
			"kms_deletion_window_days": 7,
			"tags": map[string]string{
				"Environment": "test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, kmsOptions)
	terraform.InitAndApply(t, kmsOptions)

	s3KeyARN := terraform.Output(t, kmsOptions, "s3_encryption_key_arn")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/guardduty",
		Vars: map[string]interface{}{
			"name_prefix":                    namePrefix,
			"enable_guardduty":               true,
			"guardduty_findings_bucket_name": findingsBucketName,
			"s3_encryption_key_arn":          s3KeyARN,
			"prevent_destroy":                false,
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "guardduty-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	detectorID := terraform.Output(t, terraformOptions, "detector_id")
	detectorARN := terraform.Output(t, terraformOptions, "detector_arn")
	findingsBucketARN := terraform.Output(t, terraformOptions, "findings_bucket_arn")

	assert.NotEmpty(t, detectorID, "GuardDuty detector ID should not be empty")
	assert.NotEmpty(t, detectorARN, "GuardDuty detector ARN should not be empty")
	assert.NotEmpty(t, findingsBucketARN, "Findings bucket ARN should not be empty")
}
