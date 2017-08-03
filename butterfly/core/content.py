import markdown

class Content:
    def __init__(self, markdown):
        self._markdown = markdown

    def get_content_html(self):
        # TODO: remove meta-tags.
        return markdown.markdown(self._markdown)