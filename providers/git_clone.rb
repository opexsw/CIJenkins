use_inline_resources if defined?(use_inline_resources)

action :sync do
  begin
 
	m_url="#{new_resource.repo}".sub(/^http[s]*:\/\//,'')

	m_git_repo=m_url.match(/[a-zA-Z0-9_-]*.git/)
	git_repo=m_git_repo.to_s.split(".")

	final_git_url="https://#{new_resource.username}:#{new_resource.password}@#{m_url.strip}" 
 
	git "#{new_resource.dir}" do
  		repository "#{final_git_url}"
  		action :sync
	end
  end
end 
