publish-gem:
	gem build aaf-mdqt.gemspec
	gem push aaf-mdqt-*.gem
	rm aaf-mdqt-*.gem