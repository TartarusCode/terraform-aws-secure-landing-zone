package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBudgetModule(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	namePrefix := "test-bgt-" + uniqueID

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
		TerraformDir: "../modules/budget",
		Vars: map[string]interface{}{
			"name_prefix":            namePrefix,
			"enable_budget_alerts":   true,
			"enable_budget_actions":  false,
			"budget_limit_usd":       100.0,
			"budget_alert_subscribers": []string{"test@example.com"},
			"sns_encryption_key_arn": snsKeyARN,
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "budget-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	budgetID := terraform.Output(t, terraformOptions, "budget_id")
	budgetARN := terraform.Output(t, terraformOptions, "budget_arn")
	snsTopicARN := terraform.Output(t, terraformOptions, "sns_topic_arn")

	assert.NotEmpty(t, budgetID, "Budget ID should not be empty")
	assert.NotEmpty(t, budgetARN, "Budget ARN should not be empty")
	assert.NotEmpty(t, snsTopicARN, "SNS topic ARN should not be empty")
}
