window.WWWW ?= {}

class WWWW.FeedbackHandler

  constructor: ->
    @_feedbackSubmitted = false
    @_socialClicked = false
    $("#feedback-answer").slideUp()
    $("#feedback-fail").slideUp()

    WWWW.executePHPFunction "getSessionID", "", (session_id) =>
      unless WWWW.DRY_RUN
        $("#submit-feedback").click () =>
          unless @_feedbackSubmitted
            email = $('input[name=email]').val()
            message = $('textarea[name=message]').val()

            if email isnt "" or message isnt ""
              send =
                table: "feedback"
                values: "'#{session_id}', '#{email}', '#{message}'"
                names: "`session_id`, `email`, `message`"

              WWWW.executePHPFunction "insertIntoDB", send, (response) =>
                @_feedbackSubmitted = true
                console.log "Feedback was submitted with response #{response}"
                $("#feedback-fail").slideUp()
                $("#feedback-answer").hide().slideDown()

        $(".btn-social-icon").click () =>
          unless @_socialClicked
            send =
              table: "feedback"
              values: true
              names: "`social_clicked`"

            WWWW.executePHPFunction "insertIntoDB", send, (response) =>
              @_socialClicked = true
              console.log "Feedback was submitted with response #{response}"
              $("#feedback-answer").slideUp()
              $("#feedback-fail").hide().slideDown()

        $("#next-round").click () =>
          @_feedbackSubmitted = false
          @_socialClicked = false

