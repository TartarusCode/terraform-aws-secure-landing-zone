package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestConfigModule(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	namePrefix := "test-cfg-" + uniqueID
	bucketName := "test-config-" + uniqueID

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

	snsKeyARN := terraform.Output(t, kmsOptions, "sns_encryption_key_arn")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/config",
		Vars: map[string]interface{}{
			"name_prefix":            namePrefix,
			"config_bucket_name":     bucketName,
			"sns_encryption_key_arn": snsKeyARN,
			"config_rules": map[string]string{
				"s3-bucket-public-read-prohibited":  "S3_BUCKET_PUBLIC_READ_PROHIBITED",
				"s3-bucket-public-write-prohibited": "S3_BUCKET_PUBLIC_WRITE_PROHIBITED",
			},
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "config-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	recorderName := terraform.Output(t, terraformOptions, "recorder_name")
	ruleARNs := terraform.OutputMap(t, terraformOptions, "rule_arns")

	assert.NotEmpty(t, recorderName, "Config recorder name should not be empty")
	assert.NotEmpty(t, ruleARNs, "Config rule ARNs should not be empty")
}
