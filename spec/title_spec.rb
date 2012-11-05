require 'spec_helper'

describe "Mods Title" do
  
  before(:all) do
    @mods_rec = Mods::Record.new
  end
    
  it "should recognize type attribute on titleInfo element" do
    Mods::TitleInfo::TYPES.each { |t|
      @mods_rec.from_str("<mods><titleInfo type='#{t}'>hi</titleInfo></mods>")
      @mods_rec.title_info.type.text.should == t
    }
  end
  
  it "should recognize subelements" do
    Mods::TitleInfo::SUBELEMENTS.each { |e|
      @mods_rec.from_str("<mods><titleInfo><#{e}>oofda</#{e}></titleInfo></mods>")
      @mods_rec.title_info.send(e).text.should == "oofda"
    }
  end
  
  it "should have convenience methods for getting an Array of results when there are multiple elements" do
    @mods_rec.from_str("<mods><titleInfo><title>1</title><title>2</title></titleInfo></mods>")
    @mods_rec.titles.should == ['1', '2']
  end

  context "title (basic vanilla flavor)" do
    
    it "should ignore alternative title, if it exists" do
      @mods_rec.from_str('<mods><titleInfo type="alternative"><title>ta da!</title></titleInfo></mods>')
      @mods_rec.title.text.should == []
    end

    it "should get any non-alternative title" do
      Mods::TitleInfo::TYPES.each { |t|  
        if t != "alternative"
          @mods_rec.from_str("<mods><titleInfo type='#{t}'><title>hi</title></titleInfo></mods>")
          @mods_rec.title_info.title.text.should == t
        end
      }
    end
    
    it "should start with nonSort element" do
      @mods_rec.from_str('<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>')
      @mods_rec.title_info.title.text.should == ["The Jerk"]
      @mods_rec.title.text.should == ["The Jerk"]
    end
    
    it "should not include subtitle" do
      @mods_rec.from_str('<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>')
      @mods_rec.title_info.title.text.should == ["The Jerk"]
      @mods_rec.title.text.should == ["The Jerk"]
    end

  end
  
  context "full_title" do
    it "should start with nonSort element" do
      @mods_rec.from_str('<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>')
      @mods_rec.title_info.title.text.should == ["The Jerk"]
      @mods_rec.title.text.should == ["The Jerk"]
    end
    
    it "should include subtitle" do
      @mods_rec.from_str('<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>')
      @mods_rec.title_info.title.text.should == ["The Jerk A Tale of Tourettes"]
      @mods_rec.title.text.should == ["The Jerk A Tale of Tourettes"]
    end
        
  end

  context "sort_title" do
    it "should skip nonSort element" do
      @mods_rec.from_str('<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>')
      @mods_rec.title_info.sort_title.text.should == ["Jerk"]
      @mods_rec.sort_title.text.should == ["Jerk"]
    end
    it "should contain title and subtitle" do
      @mods_rec.from_str('<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>')
      @mods_rec.title_info.sort_title.text.should == ["Jerk A Tale of Tourettes"]
      @mods_rec.sort_title.text.should == ["Jerk A Tale of Tourettes"]
    end
    it "should have a configurable delimiter between title and subtitle" do
      m = Mods::Record.new(' : ')
      m.from_str('<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>')
      m.sort_title.text.should == ["Jerk : A Tale of Tourettes"]
    end
  end
  
  context "alternative_title" do
    it "should get an alternative title, if it exists" do
      @mods_rec.from_str('<mods><titleInfo type="alternative"><title>ta da!</title></titleInfo></mods>')
      @mods_rec.alternative_title.text.should == "ta da!"
    end

    it "should have convenience methods for getting an Array of alternative titles when there are multiple elements" do
      @mods_rec.from_str("<mods><titleInfo type='alternative'><title>1</title><title>2</title></titleInfo></mods>")
      @mods_rec.alternative_titles.should == ['1', '2']
      @mods_rec.from_str("<mods><titleInfo type='alternative'><title>1</title></titleInfo><titleInfo type='alternative'><title>2</title></titleInfo></mods>")
      @mods_rec.alternative_titles.should == ['1', '2']
    end

    it "should not get an alternative title, if it doesn't exist" do
      @mods_rec.from_str('<mods><titleInfo><title>ta da!</title></titleInfo></mods>')
      @mods_rec.alternative_title.should be_empty
      @mods_rec.from_str('<mods><titleInfo type="uniform"><title>ta da!</title></titleInfo></mods>')
      @mods_rec.alternative_title.should be_empty
    end
  end
      
end