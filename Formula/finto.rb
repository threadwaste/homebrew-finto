require 'language/go'

class Finto < Formula
  desc "An experiment to ease the burden of AWS STS's assume role on a workstation."
  homepage 'https://github.com/threadwaste/finto'

  stable { url 'https://github.com/threadwaste/finto.git', tag: '0.1.0' }
  head   { url 'https://github.com/threadwaste/finto.git' }

  depends_on 'glide' => :build
  depends_on 'go' => :build

  def install
    ENV['GOPATH'] = buildpath

    mkdir_p "#{buildpath}/src/github.com/threadwaste"
    ln_sf buildpath, "#{buildpath}/src/github.com/threadwaste/finto"

    system 'glide', 'install'
    system 'go', 'build', '-o', "#{bin}/finto", 'github.com/threadwaste/finto/cmd/finto'
  end

  def test
    system "#{bin}/finto -version"
  end
end
