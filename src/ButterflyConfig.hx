typedef ButterflyConfig =
{
  // These fields are required because atom generation is required
  var siteName : String;
  var siteUrl : String;
  var authorName : String;
  @:optional var authorEmail : String;
  @:optional var googleAnalyticsId : String;
  @:optional var homePageLayout : String;
}
