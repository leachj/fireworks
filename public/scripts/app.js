function Task(data) {
    this.description = ko.observable(data.description);
    this.fired = ko.observable(data.fired);
    this.id = ko.observable(data.id);
    this.box = ko.observable(data.box);
    this.channel = ko.observable(data.channel);
    this.polarity = ko.observable(data.polarity);
    this.selected = ko.observable(data.selected);
    this.selectedStatus = ko.computed(function() {
        return this.fired() ? "fired" : this.selected() ? "selected" : "not-selected";
    }, this);
}

function TaskViewModel() {
    var self = this;
    self.tasks = ko.observableArray([]);

    self.update = function() {
    $.getJSON("/tasks", function(raw) {
        var tasks = $.map(raw, function(item) { return new Task(item) });
        self.tasks(tasks);
    });
    };

    self.update();


    self.newTaskDesc = ko.observable();
    self.newTaskBox = ko.observable();
    self.newTaskChannel = ko.observable();
    self.newTaskPolarity = ko.observable();


    self.addTask = function() {
        
	var newtask = new Task({ description: this.newTaskDesc(), box: this.newTaskBox(), channel: this.newTaskChannel(), polarity: this.newTaskPolarity() })
        self.newTaskDesc("");
        self.newTaskBox("");
        self.newTaskChannel("");
        self.newTaskPolarity("");
	$.ajax({
          url: "/tasks/new",
          type: "POST",
          data: newtask
     	}).done(function(data){
         	self.tasks.push(newtask);
		newtask.id(data.task.id);
     	}).error(function(data){
		alert("Unable to add firework")
	});
    };

    self.destroyTask = function(task) {
	self.tasks.destroy(task);
	$.ajax({
             url: "/tasks/"+task.id(),
             type: "DELETE",
             data: task
        })
    };

   self.select= function(task) {
	$.ajax({
             url: "/tasks/"+task.id()+"/select",
             type: "GET",
	     dataType: "html",
        }).done(function(data){
		self.update();
	});
    };
}

var fireworkViewModel = new TaskViewModel();
window.setInterval(fireworkViewModel.update,2000);
ko.applyBindings(fireworkViewModel);