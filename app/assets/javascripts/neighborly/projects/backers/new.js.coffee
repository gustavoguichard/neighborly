Neighborly.Projects = {} if Neighborly.Projects is undefined
Neighborly.Projects.Backers = {} if Neighborly.Projects.Backers is undefined

Neighborly.Projects.Backers.New =
  modules: -> []

  init: Backbone.View.extend
    el: '.new-backer-page'

    initialize: ->
      _.bindAll this, 'resetReward', 'clickReward', 'clickAnonymous'

      # bind change event (support for ie8 )
      this.$('#backer_value').change this.resetReward
      this.$('input[type=radio]').change this.clickReward
      this.$('#backer_anonymous').change this.clickAnonymous

      this.value = this.$('#backer_value')
      this.rewards = this.value.data('rewards')
      this.choices = this.$('.reward-option')
      this.selectReward this.$('input[type=radio]:checked')

    clickAnonymous: ->
      this.$('.anonymous-warning').fadeToggle()

    clickReward: (event) ->
      this.choices.removeClass('selected')
      option = this.$(event.currentTarget)
      this.$('.custom.radio.checked').not(option.find('~ span')).removeClass('checked')
      this.selectReward option
      this.value.val this.reward().minimum_value
      reward.parents('.reward-option:first').addClass('selected')

    reward: ->
      $reward = this.$('input[type=radio]:checked')
      if $reward.length > 0
        reward = {}
        for r in this.rewards
          reward = r if parseInt(r.id) is parseInt($reward.val())

        return reward

    selectReward: ($reward) ->
      $reward.prop 'checked', true
      this.$('.custom.radio.checked').removeClass('checked')
      $reward.find('~ span').addClass('checked')

    resetReward: (event) ->
      reward = this.reward()
      if reward
        value = this.value.val()
        this.selectReward this.$('#backer_reward_id') if (!(/^(\d+)$/.test(value))) or (parseInt(value) < reward.minimum_value)

