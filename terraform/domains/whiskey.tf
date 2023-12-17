locals {
  domain_name = "whiskey"
  events = [
    {
      name              = "whiskey.cdc.distillery.v1",
      partition_count   = 4,
      message_retention = 4,
      consumer_groups   = ["beer.lake", "whiskey.reviews"]
    },
    {
      name              = "whiskey.fct.whiskeyreview.v1",
      partition_count   = 4,
      message_retention = 4,
      consumer_groups   = ["whiskey.lake", "marketing.crm"]
    }
  ]
}
