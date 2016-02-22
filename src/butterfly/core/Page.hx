package butterfly.core;

class Page extends Content
{
  private static var orderRegex = ~/meta-order: (-?\d+)/i;
  private static inline var DEFAULT_ORDER:Int = 0;

  public var order(default, default) : Int = DEFAULT_ORDER;

  public override function parse(pathAndFileName:String) : String
  {
    var markdown:String = super.parse(pathAndFileName);
    this.order = getOrder(markdown);
    return markdown;
  }

  private static function getOrder(markdown:String) : Int
  {
    if (orderRegex.match(markdown))
    {
      var orderString:String = orderRegex.matched(1); // first group
      var order:Int = Std.parseInt(orderString);
      if (order == null) {
        throw 'Regex matched an order that is not an int: ${orderString}';
      } else {
        return order;
      }
    } else {
      return DEFAULT_ORDER;
    }
  }
}
