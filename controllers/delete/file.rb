require 'sinatra'

# Class for route /delete/file
class FileSystemSyncAPI < Sinatra::Base
    post '/delete/file/?' do
    begin
      username, path = JsonParser.call(request, 'username', 'path')
      username = username.to_s
      path = path.to_s
      tree = self.get_tree(username)
      pathUnits, fname = SplitPath.call(path, true)
      pdir = (pathUnits.size <= 1) ? tree.root_dir : tree.find_file(pathUnits)
      if pdir == nil
        logger.info 'The specified file does not exist!!'
        status 403
      else
        gaccount_gfid_list = pdir.delete_file(fname)
        if gaccount_gfid_list.size > 0
          logger.info 'DELETE FILE SUCCESSFULLY'
          logger.info "DELETED Gaccounts/Gfid(s): #{gaccount_gfid_list.join(' ')}"
          body gaccount_gfid_list.join("\n")
          status 200
        else
          logger.info 'The specified file does not exist!!'
          status 403
        end
      end
    rescue => e
      logger.info "FAILED to delete the file: #{e.inspect}"
      status 400
    end
  end
end