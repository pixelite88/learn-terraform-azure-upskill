module "moj_testowy_modul" {
    source = "./inner"
}

output "moj_inner_output" {
  value = module.moj_testowy_modul.moj_testowy_output
}