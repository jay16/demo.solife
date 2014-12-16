describe("App", function() {
  var input;

  beforeEach(function() {
    loadFixtures("teas.html");
    this.input = "#showall";
  });

  describe("loading dialog's show or hide", function() {
    it("should hide the loading dialog", function() {
      App.hideLoading();
      expect($(".loading").hasClass('hidden')).toBeTruthy()
    });

    it("should show the loading dialog", function() {
      App.showLoading();
      expect($(".loading").hasClass('hidden')).not.toBeTruthy()
    });

    it("should show the loading dialog with customer text", function() {
      var date = new Date();
      var text = date.toUTCString();

      App.showLoading(text)
      expect($(".loading").html()).toEqual(text)
    });

    it("should reset the loading text when hide", function() {
      App.hideLoading()
      expect($(".loading").html()).toEqual("loading...")
    });
  });

  describe("input[type=checkbox]'s checked state", function() {
    // checkbox state: show all teas (onsale/outsale)
    it("should return false by default", function() {
      var checkbox_num = $("input[type='checkbox']").length;
      expect(checkbox_num).toBeGreaterThan(1)

      // continue if above condition pass
      // default not checked, whether show all teas.
      expect(App.checkboxState(this.input)).toBeFalsy()
    });

    it("should return it's checked state when click it", function(){
      // unchecked by default
      expect(App.checkboxState(this.input)).toBeFalsy()

      App.checkboxChecked(this.input)
      expect(App.checkboxState(this.input)).toBeTruthy()

      App.checkboxUnChecked(this.input)
      expect(App.checkboxState(this.input)).toBeFalsy()
    });
  });
});
