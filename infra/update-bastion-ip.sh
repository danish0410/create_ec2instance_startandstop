#!/bin/bash

# -----------------------------------------------
# update-bastion-ip.sh
# Dynamically updates your Terraform tfvars file
# with your current public IP for SSH ingress.
# -----------------------------------------------

# Exit on error
set -e

# File to update
TFVARS_FILE="terraform.tfvars"

# Get current public IP
echo "Fetching current public IP..."
CURRENT_IP=$(curl -s https://checkip.amazonaws.com | tr -d '[:space:]')

# Validate IP format
if [[ ! $CURRENT_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "❌ Failed to detect valid public IP. Got: $CURRENT_IP"
  exit 1
fi

# Format as CIDR
CIDR="${CURRENT_IP}/32"

echo "✅ Detected public IP: $CIDR"
echo "Updating ${TFVARS_FILE} ..."

# Replace or add line
if grep -q "cidr_blocks_ingress_bastion" "$TFVARS_FILE"; then
  sed -i.bak -E "s|cidr_blocks_ingress_bastion *= *\[\"[0-9./]+\"\]|cidr_blocks_ingress_bastion = [\"${CIDR}\"]|" "$TFVARS_FILE"
else
  echo "" >> "$TFVARS_FILE"
  echo "cidr_blocks_ingress_bastion = [\"${CIDR}\"]" >> "$TFVARS_FILE"
fi

echo "✅ ${TFVARS_FILE} updated successfully."
echo "-----------------------------------------"
grep "cidr_blocks_ingress_bastion" "$TFVARS_FILE"
echo "-----------------------------------------"

# Ask to run Terraform
read -p "Do you want to run 'terraform apply'? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "🚀 Running Terraform..."
  terraform init -backend-config="backend-ap-south-1.hcl"
  terraform apply -var-file="$TFVARS_FILE" -auto-approve
else
  echo "Skipped Terraform apply. Run manually later."
fi
