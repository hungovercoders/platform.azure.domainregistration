locals {
  domain_name = "beer"
  events = [
    {
      name              = "beer.cdc.pub.v1",
      partition_count   = 4,
      message_retention = 4,
      consumer_groups   = ["beer.lake", "beer.reviews"]
    },
    {
      name              = "beer.fct.pintreview.v1",
      partition_count   = 4,
      message_retention = 4,
      consumer_groups   = ["beer.lake", "marketing.crm"]
    }
  ]
}
