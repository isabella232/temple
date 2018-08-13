require 'helper'

class UniqueTest
  include Temple::Utils
end

describe Temple::Utils do
  it 'has empty_exp?' do
    Temple::Utils.empty_exp?([:multi]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi]]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi, [:newline]], [:newline]]).should.be.true
    Temple::Utils.empty_exp?([:multi]).should.be.true
    Temple::Utils.empty_exp?([:multi, [:multi, [:static, 'text']]]).should.be.false
    Temple::Utils.empty_exp?([:multi, [:newline], [:multi, [:dynamic, 'text']]]).should.be.false
  end

  it 'has unique_name' do
    u = UniqueTest.new
    u.unique_name.should.equal '_uniquetest1'
    u.unique_name.should.equal '_uniquetest2'
    UniqueTest.new.unique_name.should.equal '_uniquetest1'
  end

  it 'has escape_html' do
    Temple::Utils.escape_html('<').should.equal '&lt;'
  end

  it 'can escape angular templating' do
    with_html_safe do
      Temple::Utils.set_escape_html_proc(Temple::Utils.internal_escape_html_proc)
      Temple::Utils.escape_html('{{ 1 + 1 }}').should.equal '\{\{ 1 + 1 \}\}'
      Temple::Utils.escape_html("{\x00{ 1 + 1 }\x00}").should.equal '\{\{ 1 + 1 \}\}'
      Temple::Utils.escape_html("{\x00\x00{ 1 + 1 }\x00\x00}").should.equal '\{\{ 1 + 1 \}\}'
    end
  end

  it 'can replace html escaping' do
    with_html_safe do
      begin
        # verify that if we set a custom html escape transform, it actually gets used
        prev = Temple::Utils.set_escape_html_proc(lambda {|html| "fore #{html} aft" })
        Temple::Utils.escape_html('{{ 1 + 1 }}').should.equal 'fore {{ 1 + 1 }} aft'
        Temple::Utils.escape_html('<').should.equal 'fore < aft'
      ensure
        Temple::Utils.set_escape_html_proc(prev)
      end
    end
  end

  it 'should escape unsafe html strings' do
    with_html_safe do
      Temple::Utils.escape_html_safe('<').should.equal '&lt;'
    end
  end

  it 'should not escape safe html strings' do
    with_html_safe do
      Temple::Utils.escape_html_safe('<'.html_safe).should.equal '<'
    end
  end
end
