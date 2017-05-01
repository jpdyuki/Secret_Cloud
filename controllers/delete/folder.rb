require 'sinatra'

# Class for route /delete/folder
class FileSystemSyncAPI < Sinatra::Base
    post '/delete/folder/?' do
    begin
      username, path = JsonParser.call(request, 'username', 'path')
      tree = self.get_tree(GetAccountID.call(username))
      pathUnits = SplitPath.call(path)
      pdir = (pathUnits.size <= 1) ? tree.root_dir : tree.find_file(pathUnits[0..-2])
      dir = tree.find_file(pathUnits)
      if dir == nil
        logger.info 'The specified folder does not exist!!'
        status 403
      else
        dir.recur_delete
        pdir.list.delete(dir)
        logger.info 'DELETE FOLDER SUCCESSFULLY'
        status 200
      end
    rescue => e
      logger.info "FAILED to delete the folder: #{e.inspect}"
      status 400
    end
  end
end