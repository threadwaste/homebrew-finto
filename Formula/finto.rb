class Finto < Formula
  desc "Tool to ease the burden of AWS STS's assume role on a workstation."
  homepage "https://github.com/threadwaste/finto"

  stable { url "https://github.com/threadwaste/finto.git", :tag => "0.1.0" }
  head   { url "https://github.com/threadwaste/finto.git" }

  depends_on "glide" => :build
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    mkdir_p "#{buildpath}/src/github.com/threadwaste"
    ln_sf buildpath, "#{buildpath}/src/github.com/threadwaste/finto"

    system "glide", "install"
    system "go", "build", "-o", "#{bin}/finto", "github.com/threadwaste/finto/cmd/finto"
    (bin/"finto-service").write <<-EOS.undent
    #!/usr/bin/env bash

    ifconfig | grep "169.254.169.254" 2>&1 > /dev/null
    if [ $? -ne 0 ]
    then
      ifconfig lo0 alias 169.254.169.254
    fi

    if [ -e #{etc}/fintorc ]
    then
      if [ ! $(ps ax | grep -q "[f]into") ]
      then
        #{bin}/finto -config=#{etc}/fintorc -port 80
      fi
    else
      (>&2 echo "You need to configure #{etc}/fintorc")
      exit 1
    fi
    EOS
  end

  def caveats
    if not File.exist?(etc/"fintorc")
      s = <<-EOS.undent
      Configuration: #{etc}/fintorc

      The configuration is initially empty and the service will not be running.
      EOS
    else
      s = <<-EOS.undent
      Configuration: #/{etc}/fintorc

      Finto should be running. To update the configuration, edit #{etc}/fintorc
      and call
        `sudo brew services start threadwaste/finto/finto`
      EOS
    end
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
		<?xml version="1.0" encoding="UTF-8"?>
		<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
		<plist version="1.0">
		<dict>
			<key>KeepAlive</key>
			<true/>
			<key>Label</key>
			<string>com.threadwaste.finto</string>
			<key>ProgramArguments</key>
			<array>
				<string>/usr/bin/env</string>
				<string>bash</string>
				<string>#{bin}/finto-service</string>
			</array>
			<key>RunAtLoad</key>
			<true/>
			<key>StandardErrorPath</key>
			<string>#{var}/log/threadwaste.finto.stderr</string>
			<key>StandardOutPath</key>
			<string>#{var}/log/threadwaste.finto.stdout</string>
		</dict>
		</plist>
		EOS
	end

  test do
    system "#{bin}/finto", "-version"
  end

end
