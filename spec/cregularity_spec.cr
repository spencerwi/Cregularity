require "./spec_helper"

describe Cregularity do

    context "regex methods" do
        it "responds to regex methods" do
            re = Cregularity.new
            re.start_with("abc")
            re.match("abcdef").should be_truthy
            (re =~ "abcdef").should be_truthy
        end
    end

    context "#start_with" do
        it "matches basic characters" do
            re = Cregularity.new
            re.start_with("f")
            re.get.should eq(/^f/)
        end

        it "escapes special characters" do
            re = Cregularity.new
            re.start_with(".")
            re.get.should eq(/^\./)
        end

        it "matches basic characters" do
            re = Cregularity.new
            re.start_with(3, "x")
            re.get.should eq /^x{3}/
        end

        it "matches special identifiers" do
            re = Cregularity.new
            re.start_with(2, :digits)
            re.get.should eq /^[0-9]{2}/ 
        end
    end

    it "raises an error when called twice" do
        expect_raises(Cregularity::Error) do
            re = Cregularity.new
            re.start_with("x").start_with("x")
        end
    end

    context "#append" do
        it "adds basic characters" do
            re = Cregularity.new
            re.append("x").append("y").append("z")
            re.get.should eq /xyz/
        end

        it "also works as #then" do
            re = Cregularity.new
            re.start_with("x").maybe("y").then("z")
            re.get.should eq /^xy?z/
        end

        it "escapes special characters" do
            re = Cregularity.new
            re.between([0,2], :digits).then(".").end_with("$")
            re.get.should eq /[0-9]{0,2}\.\$$/
        end

        it "raises an error after ending" do
            expect_raises(Cregularity::Error) do
                re = Cregularity.new
                re.end_with("x").append("y")
            end
        end
    end

    context "#maybe" do
        it "recognizes basic characters" do
            re = Cregularity.new
            re.append("x").maybe("y").append("z")
            re.regex.should eq /xy?z/
            (re =~ "xyz").should eq 0
            (re =~ "xz").should eq 0
        end
    end

    context "#not" do
        it "creates a negative lookahead" do
            re = Cregularity.new
            re.append("x").not("y").append("z")
            re.regex.should eq /x(?!y)z/
            (re =~ "xzabc").should eq 0
            (re =~ "xyzabc").should be_nil
        end
    end

    context "#one_of" do
        it "creates an alternation" do
            re = Cregularity.new
            re.append("w").one_of(["x", "y"]).append("z")
            re.get.should eq /w[x|y]z/
        end
    end

    context "#between" do
        it "creates a bounded repetition" do
            re = Cregularity.new
            re.between([2,4], "x")
            re.get.should eq /x{2,4}/
        end
    end

    context "#at_least" do
        it "creates a repetition of n times at least" do
            re = Cregularity.new.at_least(3, "x")
            re.get.should eq /x{3,}/
        end
    end

    context "#at_most" do
        it "creates a repetition of n times at most" do
            re = Cregularity.new.at_most(3, "x")
            re.get.should eq /x{,3}/
        end
    end

    context "zero_or_more" do
        it "recognizes basic characters" do
            re = Cregularity.new
            re.zero_or_more("a").then("b")
            re.get.should eq /a*b/
        end

        it "recognizes special identifiers" do
            re = Cregularity.new
            re.zero_or_more(:digits)
            re.get.should eq /[0-9]*/
        end
    end

    context "one_or_more" do
        it "recognizes basic characters" do
            re = Cregularity.new
            re.one_or_more("a").then("b")
            re.get.should eq /a+b/
        end

        it "recognizes special identifiers" do
            re = Cregularity.new
            re.one_or_more(:letters)
            re.get.should eq /[A-Za-z]+/
        end
    end

    context "#end_with" do
        it "matches basic characters" do
            re = Cregularity.new
            re.append("x").end_with("y")
            re.get.should eq /xy$/
        end

        it "escapes special characters" do
            re = Cregularity.new
            re.append("x").end_with("$")
            re.get.should eq /x\$$/
        end

        it "raises an error when called twice" do
            expect_raises(Cregularity::Error) do
                re = Cregularity.new
                re.end_with("x").end_with("x")
            end
        end
    end

    context "#regex" do
        it "returns a well-formed regex" do
            re = Cregularity.new
            re.start_with("w").one_of(["x", "y"]).end_with("z")
            re.regex.should eq /^w[x|y]z$/
        end
    end

    context "special identifiers" do
        it "recognizes digits" do
            re = Cregularity.new
            re.append(2, :digits)
            re.regex.should eq /[0-9]{2}/
        end

        it "recognizes lowercase characters" do
            re = Cregularity.new
            re.append(3, :lowercase)
            re.regex.should eq /[a-z]{3}/
        end

        it "recognizes uppercase characters" do
            re = Cregularity.new
            re.append(3, :uppercase)
            re.regex.should eq /[A-Z]{3}/
        end

        it "recognizes alphanumeric characters" do
            re = Cregularity.new
            re.append(3, :alphanumeric)
            re.regex.should eq /[A-Za-z0-9]{3}/
        end

        it "recognizes spaces" do
            re = Cregularity.new
            re.append(4, :spaces)
            re.regex.should eq(/ {4}/)
        end

        it "recognizes whitespace" do
            re = Cregularity.new
            re.append(2, :whitespaces)
            re.regex.should eq /\s{2}/
        end

        it "recognizes tabs" do
            re = Cregularity.new
            re.append(1, :tab)
            re.regex.should eq /\t{1}/
        end
    end

    it "works on examples" do
        re = Cregularity.new
        re.start_with(3, :digits)
            .then("-")
            .then(2, :letters)
            .maybe("#")
            .one_of(["a","b"])
            .between([2,4], "c")
            .end_with("$")

        re.regex.should eq /^[0-9]{3}-[A-Za-z]{2}#?[a|b]c{2,4}\$$/

        (re =~ "123-xy#accc$").should eq 0
        (re =~ "999-dfbcc$").should eq 0
        (re =~ "000-df#baccccccccc$").should be_nil
        (re =~ "444-dd3ac$").should be_nil
    end
end
