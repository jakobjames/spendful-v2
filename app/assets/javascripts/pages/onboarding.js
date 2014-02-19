//= require bootstrap-tooltip
//= require bootstrap-popover
//= require_self

var tour

$(function(){
  
  $( "input.date" ).datepicker( "option", "stepMonths", 0 )
  
  tour = new Tour({
    useLocalStorage: true
  })
  
  tour.addSteps([
    {
      element: ".balance.today", 
      title: "Todays Balance", 
      content: "This is your current balance, based on your budget starting balance (which you can change in Budget Settings). It also includes any transactions you have added.",
      backdrop: true
    },
    {
      element: ".nav-settings .settings", 
      title: "Budget Settings", 
      content: "You should change the starting balance to your actual bank balance as of the start of this month. So it reflects exactly how much money you have. You can also change currency, and the name of this budget.",
      backdrop: true,
      placement: "left"
    },
    {
      element: ".income .items-body .item:first-child .add-transaction", 
      title: "Add a Transaction", 
      content: "Whenever you spend or receive money, you should record it as a transaction against an income or expense item.",
      backdrop: true,
      placement: "left"
    },
    {
      element: ".income .items-header ", 
      title: "Expected and Actual", 
      content: "The 'expected' amount is your estimate (budget) for that item, and the 'actual' amount is the total of any transactions you add to it.",
      backdrop: true,
      placement: "bottom"
    },
    {
      element: ".balance.end-of-month", 
      title: "End of Month Balance", 
      content: "This is your forecasted balance for the end of the month. It's based on your expected amounts (budget) for the month.",
      backdrop: true
    },
    {
      element: ".nav-dates", 
      title: "Change Month", 
      content: "You can skip forward to see your balance months and years into the future. It's all calculated based on your budget, so there's an incentive to keep up to date.",
      backdrop: true
    },
    {
      element: ".income .add-item", 
      title: "Add Items", 
      content: "Complete the rest of your budget by adding other items of income or expense. This will give you a more complete idea of your spending habits and a more realistic forecast.",
      backdrop: true
    }
  ])
  
})
