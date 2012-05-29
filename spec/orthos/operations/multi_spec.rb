require 'spec_helper'

describe Orthos::Operations::Multi do
  let(:multi) { Orthos::Multi.new }
  let(:easy) { Orthos::Easy.new }

  describe "#running_count" do
    context "when hydra has no easy" do
      it "returns nil" do
        multi.running_count.should be_nil
      end
    end

    context "when hydra has easy" do
      before do
        easy.url = "http://localhost:3001/"
        easy.prepare
        multi.add(easy)
        multi.trigger
      end

      it "returns 1" do
        multi.running_count.should eq(1)
      end
    end

    context "when hydra has more easys" do
      let(:another_easy) { Orthos::Easy.new }

      before do
        easy.url = "http://localhost:3001/"
        easy.prepare
        another_easy.url = "http://localhost:3001/"
        another_easy.prepare
        multi.add(easy)
        multi.add(another_easy)
        multi.trigger
      end

      it "returns 2" do
        multi.running_count.should eq(2)
      end
    end
  end

  describe "#run" do
    it
  end

  describe "#trigger" do
    it
  end

  describe "#get_timeout" do
    context "when code ok" do
      let(:timeout) { 1 }

      before do
        Orthos::Curl.expects(:multi_timeout).returns(:ok)
        multi.instance_variable_set(:@timeout, mock(:read_long => timeout))
      end

      it "doesn't raise" do
        expect{ multi.get_timeout }.to_not raise_error
      end

      context "when timeout smaller zero" do
        let(:timeout) { -1 }

        it "returns 1" do
          multi.get_timeout.should eq(1)
        end
      end

      context "when timeout bigger or equal zero" do
        let(:timeout) { 2 }

        it "returns timeout" do
          multi.get_timeout.should eq(timeout)
        end
      end
    end

    context "when code not ok" do
      before { Orthos::Curl.expects(:multi_timeout).returns(:not_ok) }

      it "raises MultiTimeout error" do
        expect{ multi.get_timeout }.to raise_error(Orthos::Errors::MultiTimeout)
      end
    end
  end

  describe "#set_fds" do
    let(:timeout) { 1 }
    let(:max_fd) { 1 }

    context "when code ok" do
      before { Orthos::Curl.expects(:multi_fdset).returns(:ok) }

      it "doesn't raise" do
        expect{ multi.set_fds(timeout) }.to_not raise_error(Orthos::Errors::MultiFdset)
      end

      context "when max_fd -1" do
        let(:max_fd) { -1 }

        before do
          multi.instance_variable_set(:@max_fd, mock(:read_int => max_fd))
          multi.expects(:sleep).with(0.001)
        end

        it "waits 100ms" do
          multi.set_fds(timeout)
        end
      end

      context "when max_fd not -1" do
        context "when code smaller zero" do
          before { Orthos::Curl.expects(:select).returns(-1) }

          it "raises Select error" do
            expect{ multi.set_fds(timeout) }.to raise_error(Orthos::Errors::Select)
          end
        end

        context "when code bigger or equal zero" do
          before { Orthos::Curl.expects(:select).returns(0) }

          it "doesn't raise" do
            expect{ multi.set_fds(timeout) }.to_not raise_error(Orthos::Errors::Select)
          end
        end
      end
    end

    context "when code not ok" do
      before { Orthos::Curl.expects(:multi_fdset).returns(:not_ok) }

      it "raises MultiFdset error" do
        expect{ multi.set_fds(timeout) }.to raise_error(Orthos::Errors::MultiFdset)
      end
    end
  end

  describe "#perform" do
    context "when no easy handles" do
      it "returns nil" do
        multi.perform.should be_nil
      end
    end

    context "when easy handle" do
      before do
        easy.url = "http://localhost:3001/"
        easy.prepare
        multi.add(easy)
      end

      it "requests" do
        multi.perform
      end

      it "sets easy" do
        multi.perform
        easy.response_code.should eq(200)
      end
    end

    context "when four easy handles" do
      let(:easies) do
        ary = []
        4.times do
          ary << another_easy = Orthos::Easy.new
          another_easy.url = "http://localhost:3001/"
          another_easy.prepare
        end
        ary
      end

      before do
        easies.each { |e| multi.add(e) }
        multi.perform
      end

      it "sets response codes" do
        easies.all?{ |e| e.response_code == 200 }.should be_true
      end
    end
  end
end