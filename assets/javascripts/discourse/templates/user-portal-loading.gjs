import DConditionalLoadingSpinner from "discourse/ui-kit/d-conditional-loading-spinner";

export default <template>
  <div class="xpeng-member-portal__loading">
    <DConditionalLoadingSpinner @condition={{true}} @size="large" />
  </div>
</template>
