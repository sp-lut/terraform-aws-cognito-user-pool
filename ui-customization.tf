locals {
  client_ids_map = { for c in aws_cognito_user_pool_client.client : c.name => c.id }

  client_ui_customizations = { for c in var.clients : c.name => {
    css        = lookup(c, "ui_customization_css", null)
    image_file = lookup(c, "ui_customization_image_file", null)
    } if lookup(c, "ui_customization_css", null) != null || lookup(c, "ui_customization_image_file", null) != null
  }

  #Check whether a default image has been provided
  default_ui_customization = var.default_ui_customization_image_file != null ? {
    css        = lookup(local.clients_default[0], "ui_customization_css", null)
    image_file = var.default_ui_customization_image_file
  } : null
}

resource "aws_cognito_user_pool_ui_customization" "ui_customization" {
  for_each = local.client_ui_customizations

  client_id = local.client_ids_map[each.key]

  css        = each.value.css
  image_file = each.value.image_file

  user_pool_id = aws_cognito_user_pool.pool[0].id
}

resource "aws_cognito_user_pool_ui_customization" "default_ui_customization" {
  count = var.default_ui_customization_image_file != null ? 1 : 0

  css        = local.default_ui_customization.css
  image_file = local.default_ui_customization.image_file
  user_pool_id = aws_cognito_user_pool.pool[0].id
}
