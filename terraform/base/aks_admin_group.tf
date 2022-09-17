# create ad application
#resource "azuread_application" "app" {
#  display_name = var.aad_app
#}
# create service_principal
#resource "azuread_service_principal" "spn" {
#  application_id = azuread_application.app.application_id
#}

resource "azuread_group" "aks_admins" {
  display_name     = var.aad_group_aks_admins
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]

  #members = [
    #data.azuread_client_config.current.object_id,
    #azuread_service_principal.spn.id
 # ]
}
# add current to aks admin group
resource "azuread_group_member" "current_member" {
  member_object_id = data.azuread_client_config.current.object_id
  group_object_id  = azuread_group.aks_admins.id
}