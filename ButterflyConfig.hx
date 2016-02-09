typedef ButterflyConfig =
{
  // These four fields are required because atom generation is required
  var siteName : String;
  var siteUrl : String;
  var authorName : String;
  var authorEmail : String;
  @optional var googleAnlyticsId : String;
  @optional var disqus : String; // TODO: remove if unused
  @optional var linkAttributes : String;
  @optional var linkPrefix : String;
  @optional var linkSuffix : String;
}
