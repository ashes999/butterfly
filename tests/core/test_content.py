import unittest
from butterfly.core.content import Content

class TetsContent(unittest.TestCase):
    
    def test_get_content_html_gets_markdown_rendered_html(self):
        markdown = "# Hello, world! Link to [Google](http://google.ca)."
        expected = '<h1>Hello, world! Link to <a href="http://google.ca">Google</a>.</h1>'
        actual = Content(markdown).get_content_html()
        self.assertEqual(expected, actual)

if __name__ == '__main__':
    unittest.main()