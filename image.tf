##############################################################################
# This file creates custom image using F5-BIGIP qcow2 image hosted in vnfsvc COS
#  - Creates IAM Authorization Policy in vnfsvc account
#  - Creates Custom Image in User account
#
# Note: There are following gaps in ibm is provider and thus using Terraform tricks
# to overcome the gaps for the PoC sake.
# Gap1: IBM IS Provider missing resource implementation for is_image (Create, update, delete)
# Gap2: IBM IS provider missing data source to read logged user provider session info
# example: account-id
##############################################################################

# =============================================================================
# Hack: parse out the user account from the vpc resource crn
# Fix: Get data_source_ibm_iam_target added that would provide information
# about user from provider session
# =============================================================================
locals {
  image_url = "${var.ibmcloud_endpoint == "cloud.ibm.com" ? var.vnf_cos_image_url : var.vnf_cos_image_url_test}"
}

# Generating random ID
resource "random_uuid" "test" { }

resource "ibm_is_image" "f5_custom_image" {
  depends_on       = ["random_uuid.test"]
  href             = "${local.image_url}"
  name             = "${var.vnf_vpc_image_name}-${substr(random_uuid.test.result,0,8)}"
  operating_system = "centos-7-amd64"

  timeouts {
    create = "30m"
    delete = "10m"
  }
}

data "ibm_is_image" "f5_custom_image" {
  name       = "${var.vnf_vpc_image_name}-${substr(random_uuid.test.result,0,8)}"
  depends_on = ["ibm_is_image.f5_custom_image"]
}
