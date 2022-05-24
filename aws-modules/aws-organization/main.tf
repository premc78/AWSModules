// this return information about org: https://www.terraform.io/docs/providers/aws/d/organizations_organization.html
data "aws_organizations_organization" "myRoot"{
}

/*
data.aws_organizations_organization.myRoot.roots[0].id
data.aws_organizations_organization.myRoot.roots[0].name
data.aws_organizations_organization.myRoot.roots[0].arn
*/

// root will only have 1 element, but we leave this open-ended for consistency with the remaining levels
data "aws_organizations_organizational_units" "level1_ou"{
    count = length(data.aws_organizations_organization.myRoot.roots)
    parent_id = data.aws_organizations_organization.myRoot.roots[count.index].id
}

/* 
data.aws_organizations_organizational_units.level1_ou[*].parent_id
data.aws_organizations_organizational_units.level1_ou[*].id  <-- don't use this
data.aws_organizations_organizational_units.level1_ou[*].children[*].id
data.aws_organizations_organizational_units.level1_ou[*].children[*].arn
data.aws_organizations_organizational_units.level1_ou[*].children[*].name 
*/

locals {
    level1_ou_flat = flatten([
        for ou in data.aws_organizations_organizational_units.level1_ou : [
            for child in ou.children : {
                parent_id = ou.parent_id
                parent_name = data.aws_organizations_organization.myRoot.roots[0].name
                id = child.id
                name = child.name
                arn = child.arn
                path = "${data.aws_organizations_organization.myRoot.roots[0].name}/${child.name}"
            }
        ]
    ])        
}
/*
local.level1_ou_flat[*].parent_id
local.level1_ou_flat[*].parent_name
local.level1_ou_flat[*].id
local.level1_ou_flat[*].name
local.level1_ou_flat[*].arn
local.level1_ou_flat[*].path
*/

locals {
  something = flatten([
      for name in var.org_units : [
        for ou in local.level1_ou_flat:
            ou.id
        if ou.name == name
      ]
  ])
}
output "specific_ou" {
    value = local.something
}

// this returns a list of list of OUs on layer 2
data "aws_organizations_organizational_units" "level2_ou"{
    count = length(local.level1_ou_flat)
    parent_id = local.level1_ou_flat[count.index].id 
}

/* 
data.aws_organizations_organizational_units.level2_ou[*].parent_id
data.aws_organizations_organizational_units.level2_ou[*].id  <-- don't use this
data.aws_organizations_organizational_units.level2_ou[*].children[*].id
data.aws_organizations_organizational_units.level2_ou[*].children[*].arn
data.aws_organizations_organizational_units.level2_ou[*].children[*].name 
*/

// flatten the list of list layer 2
locals {
    level2_ou_flat = flatten([
        for ou in data.aws_organizations_organizational_units.level2_ou : [
            for child in ou.children : {
                parent_id = ou.parent_id
                parent_name = [for x in local.level1_ou_flat: x.name if x.id == ou.parent_id][0]
                id = child.id
                name = child.name
                arn = child.arn
                path = "${[for x in local.level1_ou_flat: x.path if x.id == ou.parent_id][0]}/${child.name}"
            }
        ]
    ])        
}

/*
local.level2_ou_flat[*].parent_id
local.level2_ou_flat[*].parent_name
local.level2_ou_flat[*].id
local.level2_ou_flat[*].name
local.level2_ou_flat[*].arn
local.level2_ou_flat[*].path
*/

// this returns a list of list of OUs on layer 3
data "aws_organizations_organizational_units" "level3_ou"{
    count = length(local.level2_ou_flat)
    parent_id = local.level2_ou_flat[count.index].id
}

// flatten the list of list layer 3
locals {
    level3_ou_flat = flatten([
        for ou in data.aws_organizations_organizational_units.level3_ou : [
            for child in ou.children : {
                parent_id = ou.parent_id
                parent_name = [for x in local.level2_ou_flat: x.name if x.id == ou.parent_id][0]
                id = child.id
                name = child.name
                arn = child.arn
                path = "${[for x in local.level2_ou_flat: x.path if x.id == ou.parent_id][0]}/${child.name}"
            }
        ]
    ])        
}

// this returns a list of list of OUs on layer 4
data "aws_organizations_organizational_units" "level4_ou"{
    count = length(local.level3_ou_flat)
    parent_id = local.level3_ou_flat[count.index].id
}

// flatten the list of list layer 4
locals {
    level4_ou_flat = flatten([
        for ou in data.aws_organizations_organizational_units.level4_ou : [
            for child in ou.children : {
                parent_id = ou.parent_id
                parent_name = [for x in local.level3_ou_flat: x.name if x.id == ou.parent_id][0]
                id = child.id
                name = child.name
                arn = child.arn
                path = "${[for x in local.level3_ou_flat: x.path if x.id == ou.parent_id][0]}/${child.name}"
            }
        ]
    ])        
}

// this returns a list of list of OUs on layer 5
data "aws_organizations_organizational_units" "level5_ou"{
    count = length(local.level4_ou_flat)
    parent_id = local.level4_ou_flat[count.index].id
}

// flatten the list of list layer 5
locals {
    level5_ou_flat = flatten([
        for ou in data.aws_organizations_organizational_units.level5_ou : [
            for child in ou.children : {
                parent_id = ou.parent_id
                parent_name = [for x in local.level4_ou_flat: x.name if x.id == ou.parent_id][0]
                id = child.id
                name = child.name
                arn = child.arn
                path = "${[for x in local.level4_ou_flat: x.path if x.id == ou.parent_id][0]}/${child.name}"
            }
        ]
    ])        
}


locals {
    // AWS Organization currently only supports 1 root
    root_id = data.aws_organizations_organization.myRoot.roots[0].id
    root_accounts = data.aws_organizations_organization.myRoot.accounts[*].id
    all_ou = concat(local.level1_ou_flat,local.level2_ou_flat,local.level3_ou_flat,local.level4_ou_flat,local.level5_ou_flat)

    /*
    local.all_ou[*].parent_id
    local.all_ou[*].parent_name
    local.all_ou[*].id
    local.all_ou[*].name
    local.all_ou[*].arn
    local.all_ou[*].path
    */
}


output "ou_tree" {
  value = local.all_ou
}
