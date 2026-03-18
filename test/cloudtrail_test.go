package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestCloudTrailModule(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	namePrefix := "test-ct-" + uniqueID
	bucketName := "test-cloudtrail-" + uniqueID

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
		TerraformDir: "../modules/cloudtrail",
		Vars: map[string]interface{}{
			"name_prefix":            namePrefix,
			"cloudtrail_bucket_name": bucketName,
			"cloudtrail_enable_kms":  true,
			"s3_encryption_key_arn":  s3KeyARN,
			"enable_cloudwatch_logs": true,
			"log_retention_days":     7,
			"prevent_destroy":        false,
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "cloudtrail-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	bucketARN := terraform.Output(t, terraformOptions, "bucket_arn")
	cloudtrailARN := terraform.Output(t, terraformOptions, "cloudtrail_arn")
	cwLogGroup := terraform.Output(t, terraformOptions, "cloudwatch_log_group_name")

	assert.NotEmpty(t, bucketARN, "Bucket ARN should not be empty")
	assert.NotEmpty(t, cloudtrailARN, "CloudTrail ARN should not be empty")
	assert.NotEmpty(t, cwLogGroup, "CloudWatch Log Group name should not be empty")
}
