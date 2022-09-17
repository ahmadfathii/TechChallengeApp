
resource "azuread_application" "app" {
  display_name = var.aad_app  #ad_app_aks_servian
}
# create service_principal
resource "azuread_service_principal" "spn" {
  application_id = azuread_application.app.application_id
}
# create spn password
resource "azuread_service_principal_password" "spn_password" {
  service_principal_id = azuread_service_principal.spn.id
}
# add spn to aks admin group
resource "azuread_group_member" "spn_member" {
  group_object_id  = data.azuread_group.aks_admins.id
  member_object_id = azuread_service_principal.spn.object_id 
}