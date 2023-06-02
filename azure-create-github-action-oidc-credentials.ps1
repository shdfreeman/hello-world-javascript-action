
# set up azure OIDC authentication (OIDC is preferred over service principal)
#   https://dev.to/pwd9000/bk-1iij

# variables
$appName = "GitHub-Actions-OIDC"
$RBACRole = "Contributor"

$githubOrgName = "shdfreeman"
$githubRepoName = "hello-world-javascript-action"
$githubBranch = "main"

# azure cli connection
az login
az account show

$subscriptionId = $(az account show --query id -o tsv)

# Create AAD App and Principal
$appId = $(az ad app create --display-name $appName --query appId -o tsv)
az ad sp create --id $appId

# Create federated GitHub credentials (Entity type 'Branch')
$githubBranchConfig = [PSCustomObject]@{
    name        = "GH-[$githubOrgName-$githubRepoName]-Branch-[$githubBranch]"
    issuer      = "https://token.actions.githubusercontent.com"
    subject     = "repo:" + "$githubOrgName/$githubRepoName" + ":ref:refs/heads/$githubBranch"
    description = "Federated credential linked to GitHub [$githubBranch] branch @: [$githubOrgName/$githubRepoName]"
    audiences   = @("api://AzureADTokenExchange")
}
$githubBranchConfigJson = $githubBranchConfig | ConvertTo-Json
$githubBranchConfigJson | az ad app federated-credential create --id $appId --parameters "@-"

# Create federated GitHub credentials (Entity type 'Pull Request')
$githubPRConfig = [PSCustomObject]@{
    name        = "GH-[$githubOrgName-$githubRepoName]-PR"
    issuer      = "https://token.actions.githubusercontent.com"
    subject     = "repo:" + "$githubOrgName/$githubRepoName" + ":pull_request"
    description = "Federated credential linked to GitHub Pull Requests @: [$githubOrgName/$githubRepoName]"
    audiences   = @("api://AzureADTokenExchange")
}
$githubPRConfigJson = $githubPRConfig | ConvertTo-Json
$githubPRConfigJson | az ad app federated-credential create --id $appId --parameters "@-"

### Additional federated GitHub credential entity types are 'Tag' and 'Environment' (see: https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azcli#github-actions-example) ###

# Assign RBAC permissions to Service Principal (Change as necessary)
$appId | foreach-object {

    # Permission 1 (Example)
    az role assignment create `
        --role $RBACRole `
        --assignee $_ `
        --subscription $subscriptionId

    # Permission 2 (Example)
    #az role assignment create `
    #    --role "Reader and Data Access" `
    #    --assignee "$_" `
    #    --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageName"
}
