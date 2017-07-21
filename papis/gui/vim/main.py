import os
import re
import textwrap
import subprocess
import tempfile
import logging
import papis.config
import papis.commands.external


class Gui(object):

    def __init__(self):
        self.documents = []
        self.logger = logging.getLogger("gui:vim")
        self.main_vim_path = os.path.join(
            os.path.dirname(__file__),
            "main.vim"
        )

    def export_variables(self, args):
        """Export variables so that vim can use some papis information
        """
        external_cmd = papis.commands.external.External()
        external_cmd.set_args(args)
        external_cmd.export_variables()

    def main(self, documents, args):
        header_format = papis.config.get(
            "vim-header-format",
            default=textwrap.dedent("""\
            Title : {doc[title]}
            Author: {doc[author]}
            Year  : {doc[year]}
            -------
            """)
        )
        self.export_variables(args)
        temp_file = tempfile.mktemp()
        self.logger.debug("Temp file = %s" % temp_file)
        fd = open(temp_file, "w+")
        for doc in documents:
            fd.write(
                header_format.format(doc=doc)
            )
        fd.close()

        subprocess.call(
                ["vim", "-S", self.main_vim_path, temp_file]
        )
