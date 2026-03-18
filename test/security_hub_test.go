package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSecurityHubModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/security_hub",
		Vars: map[string]interface{}{
			"enable_security_hub":   true,
			"enable_cis_standard":   true,
			"enable_pci_standard":   false,
			"enable_fsbp_standard":  true,
			"enable_action_targets": true,
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	securityHubEnabled := terraform.Output(t, terraformOptions, "security_hub_enabled")
	cisStandardEnabled := terraform.Output(t, terraformOptions, "cis_standard_enabled")
	fsbpStandardEnabled := terraform.Output(t, terraformOptions, "fsbp_standard_enabled")
	actionTargetsEnabled := terraform.Output(t, terraformOptions, "action_targets_enabled")

	assert.Equal(t, "true", securityHubEnabled, "Security Hub should be enabled")
	assert.Equal(t, "true", cisStandardEnabled, "CIS standard should be enabled")
	assert.Equal(t, "true", fsbpStandardEnabled, "FSBP standard should be enabled")
	assert.Equal(t, "true", actionTargetsEnabled, "Action targets should be enabled")
}
