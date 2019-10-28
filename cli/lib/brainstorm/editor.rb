require 'brainstorm'
require 'tempfile'

class Brainstorm::Editor

  def initialize(editor: 'vim')
    @editor = editor
  end

  def get_content()
    file = Tempfile.new('brainstorm')
    system(@editor, file.path)
    content = file.read
  ensure
    # close & delete file
    file.close(true)
  end
end