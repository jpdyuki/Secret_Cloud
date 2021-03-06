require 'sinatra'

# Class for route /filesystem
class FileSystemSyncAPI < Sinatra::Base
  # For each folder, generate a corresponding
  # hash structure for it.
  def DFS(folder)
    return nil if folder == nil
    filesystem = Hash.new
    if folder.portion == 0
      folder.list.each do |file|
        filesystem[file.name] = DFS(file)
      end
      return filesystem
    else
      return folder.name
      # For now we still assume each file has only 1 portion.
    end
  end

  post '/filesystem/?' do
    # Here we have to specify charset to tell the
    # "website" that the body content is in UTF-8
    # encoding!! Note if we call this route with
    # httpie, this specification is not required.
    content_type 'application/json; charset=utf-8'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      tree = self.get_tree(account.name)
      body self.DFS(tree.root_dir).to_json
      logger.info "RETURN FILESYSTEM SUCCESSFULLY"
      status 200
    rescue => e
      logger.info "FAILED to return the filesystem: #{e.inspect}"
      status 400
    end
  end
end
