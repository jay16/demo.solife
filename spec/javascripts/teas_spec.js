describe("Tea", function(){
  var input

  beforeEach(function() {
    loadFixtures("teas.html");
    this.input = "showall";
  });

  describe("ShowAll", function(){
    it("should unchecked by default", function() {
      var state = App.checkboxState(this.input);
      expect(state).toBeFalsy()
    })

    it("should show onsale, hide outsale by default", function() {
      var all_num     = $(".tea").length;
      var onsale_num  = $(".onsale").length;
      var outsale_num = $(".outsale").length;
      expect(onsale_num + outsale_num).toEqual(all_num);

      expect($(".onsale").hasClass("hidden")).toBeFalsy();
      expect($(".outsale").hasClass("hidden")).toBeTruthy();
      // not all hasClass("hidden")
      // expect($(".tea").hasClass("hidden")).toBeFalsy();
    })

    it("should all .teas class show when click #showall", function() {
      Teas.showAllTeas(this.input);

      expect($(".tea").hasClass("hidden")).toBeFalsy();
      expect($(".outsale").hasClass("hidden")).toBeFalsy();
    });

  });
});
