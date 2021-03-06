# Listen >=2.8 patch to silence duplicate directory errors. USE AT YOUR OWN RISK
# https://github.com/guard/listen/wiki/Duplicate-directory-errors#monkey-patch

require 'listen/record/symlink_detector'
module Listen
  class Record
    class SymlinkDetector
      def _fail(_, _)
        fail Error, "Don't watch locally-symlinked directory twice"
      end
    end
  end
end
