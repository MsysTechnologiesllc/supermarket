require 'spec_helper'

describe MarkdownHelper do
  describe '#render_markdown' do
    it 'renders markdown' do
      expect(helper.render_markdown('# Test')).to match(/h1/)
    end

    it 'renders fenced code blocks' do
      codeblock = <<-CODEBLOCK.strip_heredoc
        ```sh
        $ bundle exec rake spec:all
        ```
      CODEBLOCK

      expect(helper.render_markdown(codeblock)).to match(/<pre lang="sh"><code>/)
    end

    it 'auto renders links with target blank' do
      expect(helper.render_markdown('http://chef.io')).
        to match(Regexp.quote('<a href="http://chef.io" target="_blank">http://chef.io</a>'))
    end
  end

  it 'renders tables' do
    table = <<-TABLE.strip_heredoc
      | name | version |
      | ---- | ------- |
      | apt  | 0.25    |
      | yum  | 0.75    |
    TABLE

    expect(helper.render_markdown(table)).to match(/<table>/)
  end

  it "adds br tags on hard wraps" do
    markdown = <<~HARDWRAP.strip_heredoc
      There is a hard
      wrap.
    HARDWRAP

    expect(helper.render_markdown(markdown)).to match(/<br>/)
  end

  it "doesn't emphasize underscored words" do
    expect(helper.render_markdown('some_long_method_name')).to_not match(/<em>/)
  end

  it 'adds HTML anchors to headers' do
    expect(helper.render_markdown('# Tests')).to match(/id="tests"/)
  end

  it 'strikesthrough text using ~~ with a del tag' do
    expect(helper.render_markdown('~~Ignore This~~')).to match(/<del>/)
  end

  it 'uses protocol-relative URLs for images served over HTTP' do
    html = helper.render_markdown('![](http://img.example.com)')

    expect(html).to include('<img src="//img.example.com" alt="">')
  end

  it 'prevents XSS attacks' do
    html = helper.render_markdown("<iframe src=javascript:alert('hahaha')></iframe>")
    expect(html).to match(/&lt;iframe src=javascript:alert\(&#39;hahaha&#39;\)&gt;&lt;\/iframe&gt;/)
  end

  it 'uses protocol-relative URLs for images served over HTTPS' do
    html = helper.render_markdown('![](https://img.example.com)')

    expect(html).to include('<img src="//img.example.com" alt="">')
  end
end
