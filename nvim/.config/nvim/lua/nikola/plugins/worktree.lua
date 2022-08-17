local worktree = require("git-worktree")

worktree.on_tree_change(function(op, metadata)
	if op == worktree.Operations.Create then
		local worktree_path = "/mnt/hddstorage/files/work/BitStarz/projekti/IronMan.git/" .. metadata.path
		local secrets_path = "/mnt/hddstorage/files/work/BitStarz/projekti/secrets"
		local copy_all_cmd = "ln -s " .. secrets_path .. "/* " .. worktree_path
		local copy_hidden_cmd = "ln -s " .. secrets_path .. "/.* " .. worktree_path
		os.execute(copy_all_cmd)
		os.execute(copy_hidden_cmd)
		print(copy_all_cmd)
		print(copy_hidden_cmd)
	end
end)
