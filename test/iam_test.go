package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIAMModule(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	namePrefix := "test-iam-" + uniqueID

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/iam",
		Vars: map[string]interface{}{
			"name_prefix": namePrefix,
			"iam_roles": []map[string]interface{}{
				{
					"name":        "ReadOnlyAdmin",
					"description": "Read-only administrator role",
					"policy_arn":  "arn:aws:iam::aws:policy/ReadOnlyAccess",
				},
				{
					"name":        "PowerUserRestrictedIAM",
					"description": "Power user role with restricted IAM access",
					"policy_arn":  "arn:aws:iam::aws:policy/PowerUserAccess",
				},
			},
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "iam-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	roleARNs := terraform.OutputMap(t, terraformOptions, "role_arns")
	roleNames := terraform.OutputList(t, terraformOptions, "role_names")

	assert.NotEmpty(t, roleARNs, "Role ARNs should not be empty")
	assert.Len(t, roleNames, 2, "Should have 2 IAM roles")
}
