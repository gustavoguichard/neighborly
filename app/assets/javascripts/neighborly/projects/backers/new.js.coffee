Neighborly.Projects = {} if Neighborly.Projects is undefined
Neighborly.Projects.Backers = {} if Neighborly.Projects.Backers is undefined

Neighborly.Projects.Backers.New =
  modules: -> []

  init: Backbone.View.extend
    el: '.new-backer-page'

    events:
      'change #backer_value': 'resetReward'
      'change input[type=radio]': 'clickReward'
      'click #backer_anonymous': 'clickAnonymous'


    initialize: ->
      _.bindAll this, 'resetReward', 'clickReward'
      @value = @$('#backer_value')
      @rewards = @value.data('rewards')
      @choices = @$('.reward-option')
      @selectReward @$('input[type=radio]:checked')


    #clickAnonymous: ->
      #$('#anonymous_warning').fadeToggle()

    clickReward: (event) ->
      option = @$(event.currentTarget)
      this.$('.custom.radio.checked').not(option.find('~ span')).removeClass('checked')
      @selectReward option
      @value.val @reward().minimum_value


    reward: ->
      $reward = @$('input[type=radio]:checked')
      if $reward.length > 0
        reward = {}
        for r in @rewards
          reward = r if parseInt(r.id) is parseInt($reward.val())

        return reward

    selectReward: ($reward) ->
      $reward.prop 'checked', true
      this.$('.custom.radio.checked').removeClass('checked')
      $reward.find('~ span').addClass('checked')

    resetReward: (event) ->
      reward = @reward()
      if reward
        value = @value.val()
        @selectReward @$('#backer_reward_id') if (!(/^(\d+)$/.test(value))) or (parseInt(value) < reward.minimum_value)

