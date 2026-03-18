package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLandingZoneBasic(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	namePrefix := "test-lz-" + uniqueID

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "..",
		Vars: map[string]interface{}{
			"name_prefix":                    namePrefix,
			"cloudtrail_bucket_name":         "cloudtrail-logs",
			"guardduty_findings_bucket_name": "guardduty-findings",
			"enable_guardduty":               true,
			"enable_budget_alerts":           true,
			"enable_budget_actions":          false,
			"budget_limit_usd":               100.0,
			"budget_alert_subscribers":       []string{"test@example.com"},
			"enable_security_hub":            false,
			"enable_macie":                   false,
			"prevent_destroy":                false,
			"kms_deletion_window_days":       7,
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "landing-zone-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"Error applying plan": "Temporary infrastructure issues",
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	publicSubnetIDs := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	cloudtrailBucketARN := terraform.Output(t, terraformOptions, "cloudtrail_bucket_arn")
	guarddutyDetectorID := terraform.Output(t, terraformOptions, "guardduty_detector_id")
	budgetID := terraform.Output(t, terraformOptions, "budget_id")
	flowLogGroup := terraform.Output(t, terraformOptions, "vpc_flow_log_group_name")

	assert.NotEmpty(t, vpcID, "VPC ID should not be empty")
	assert.Len(t, publicSubnetIDs, 2, "Should have 2 public subnets")
	assert.Len(t, privateSubnetIDs, 2, "Should have 2 private subnets")
	assert.NotEmpty(t, cloudtrailBucketARN, "CloudTrail bucket ARN should not be empty")
	assert.NotEmpty(t, guarddutyDetectorID, "GuardDuty detector ID should not be empty")
	assert.NotEmpty(t, budgetID, "Budget ID should not be empty")
	assert.NotEmpty(t, flowLogGroup, "VPC Flow Log group should not be empty")

	t.Log("Basic landing zone test completed successfully")
}

func TestLandingZoneFull(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	namePrefix := "test-lzf-" + uniqueID

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "..",
		Vars: map[string]interface{}{
			"name_prefix":                    namePrefix,
			"cloudtrail_bucket_name":         "cloudtrail-logs",
			"guardduty_findings_bucket_name": "guardduty-findings",
			"enable_guardduty":               true,
			"enable_budget_alerts":           true,
			"enable_budget_actions":          false,
			"budget_limit_usd":               100.0,
			"budget_alert_subscribers":       []string{"test@example.com"},
			"enable_security_hub":            true,
			"enable_cis_standard":            true,
			"enable_pci_standard":            false,
			"enable_fsbp_standard":           true,
			"enable_action_targets":          true,
			"enable_macie":                   true,
			"enable_macie_s3_classification": false,
			"enable_s3_block_public_access":  true,
			"prevent_destroy":                false,
			"kms_deletion_window_days":       7,
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "landing-zone-full-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"Error applying plan": "Temporary infrastructure issues",
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	publicSubnetIDs := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	cloudtrailBucketARN := terraform.Output(t, terraformOptions, "cloudtrail_bucket_arn")
	guarddutyDetectorID := terraform.Output(t, terraformOptions, "guardduty_detector_id")
	budgetID := terraform.Output(t, terraformOptions, "budget_id")
	securityHubEnabled := terraform.Output(t, terraformOptions, "security_hub_enabled")
	fsbpEnabled := terraform.Output(t, terraformOptions, "fsbp_standard_enabled")
	macieEnabled := terraform.Output(t, terraformOptions, "macie_enabled")
	s3BlockEnabled := terraform.Output(t, terraformOptions, "s3_block_public_access_enabled")

	assert.NotEmpty(t, vpcID, "VPC ID should not be empty")
	assert.Len(t, publicSubnetIDs, 2, "Should have 2 public subnets")
	assert.Len(t, privateSubnetIDs, 2, "Should have 2 private subnets")
	assert.NotEmpty(t, cloudtrailBucketARN, "CloudTrail bucket ARN should not be empty")
	assert.NotEmpty(t, guarddutyDetectorID, "GuardDuty detector ID should not be empty")
	assert.NotEmpty(t, budgetID, "Budget ID should not be empty")
	assert.Equal(t, "true", securityHubEnabled, "Security Hub should be enabled")
	assert.Equal(t, "true", fsbpEnabled, "FSBP standard should be enabled")
	assert.Equal(t, "true", macieEnabled, "Macie should be enabled")
	assert.Equal(t, "true", s3BlockEnabled, "S3 Block Public Access should be enabled")

	t.Log("Full landing zone test completed successfully")
}
