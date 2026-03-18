package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	namePrefix := "test-vpc-" + uniqueID

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/vpc",
		Vars: map[string]interface{}{
			"name_prefix":        namePrefix,
			"vpc_cidr":           "10.0.0.0/16",
			"public_subnet_cidrs":  []string{"10.0.1.0/24", "10.0.2.0/24"},
			"private_subnet_cidrs": []string{"10.0.11.0/24", "10.0.12.0/24"},
			"enable_flow_logs":   true,
			"flow_log_retention": 7,
			"tags": map[string]string{
				"Environment": "test",
				"Owner":       "terratest",
				"Project":     "vpc-test",
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	publicSubnetIDs := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	natGatewayID := terraform.Output(t, terraformOptions, "nat_gateway_id")
	flowLogGroupName := terraform.Output(t, terraformOptions, "flow_log_group_name")

	assert.NotEmpty(t, vpcID, "VPC ID should not be empty")
	assert.Len(t, publicSubnetIDs, 2, "Should have 2 public subnets")
	assert.Len(t, privateSubnetIDs, 2, "Should have 2 private subnets")
	assert.NotEmpty(t, natGatewayID, "NAT Gateway ID should not be empty")
	assert.NotEmpty(t, flowLogGroupName, "Flow Log group name should not be empty")
}
