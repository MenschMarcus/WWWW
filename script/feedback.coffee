window.WWWW ?= {}

class WWWW.FeedbackHandler

  constructor: ->
    @_feedbackSubmitted = false
    @_socialClicked = false
    $("#feedback-answer").slideUp()
    $("#user-question-answer").slideUp()

    WWWW.executePHPFunction "getSessionID", "", (session_id) =>
      unless WWWW.DRY_RUN
        $("#submit-feedback").click () =>
          unless @_feedbackSubmitted
            message = $('textarea[name=message]').val()

            if message isnt ""
              send =
                table: "feedback"
                values: "'#{session_id}', '#{message}'"
                names: "`session_id`, `message`"

              WWWW.executePHPFunction "insertIntoDB", send, (response) =>
                @_feedbackSubmitted = true
                console.log "feedback was submitted with response #{response}"
                $("#feedback-answer").hide().slideDown()

        $(".btn-social-icon").click () =>
          unless @_socialClicked
            send =
              table: "feedback"
              values: "'#{session_id}', 1"
              names: "`session_id`, `social_clicked`"

            WWWW.executePHPFunction "insertIntoDB", send, (response) =>
              @_socialClicked = true
              console.log "Feedback was submitted with response #{response}"
              $("#feedback-answer").slideUp()


        $("#next-round").click () =>
          @_feedbackSubmitted = false
          @_socialClicked = false
          $("#feedback-answer").hide()
          $("#user-question-answer").hide()

        $("#submit-user-question").click () =>
          text = $('textarea[name=user-question]').val()
          location = $('input[name=user-question-location]').val()
          year = $('input[name=user-question-year]').val()
          name = $('input[name=user-question-name]').val()
          email = $('input[name=user-question-email]').val()

          $("#user-question-group").removeClass "has-error"
          $("#user-question-location-group").removeClass "has-error"
          $("#user-question-year-group").removeClass "has-error"
          $("#user-question-name-group").removeClass "has-error"
          $("#user-question-email-group").removeClass "has-error"

          if text isnt "" and location isnt "" and year isnt "" and name isnt "" and email isnt ""

            send =
              table: "user_question"
              values: "'#{session_id}', '#{text}', '#{location}', '#{year}', '#{name}', '#{email}'"
              names: "`session_id`, `text`, `location`, `year`, `name`, `email`"

            WWWW.executePHPFunction "insertIntoDB", send, (response) =>
              console.log "question was submitted with response #{response}"
              $("#user-question-answer").hide().slideDown()

          else
            if text is ""
              $("#user-question-group").addClass "has-error"
            if location is ""
              $("#user-question-location-group").addClass "has-error"
            if year is ""
              $("#user-question-year-group").addClass "has-error"
            if name is ""
              $("#user-question-name-group").addClass "has-error"
            if email is ""
              $("#user-question-email-group").addClass "has-error"

